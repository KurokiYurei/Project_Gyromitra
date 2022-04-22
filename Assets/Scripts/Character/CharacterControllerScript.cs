using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.InputSystem.InputAction;

public class CharacterControllerScript : MonoBehaviour
{
    public Camera m_Camera;

    [Header("Stats")]
    public float m_WalkSpeed = 1.5f;
    bool m_OnGround;
    public float m_JumpSpeed = 7.7f;
    float m_VerticalSpeed = 0.0f;

    public float m_fallGravityMultiplier = 2f;

    public float smoothInputSpeed = 0.1f;

    private float m_onAirTimer;
    private bool m_jumped;

    static PoolElements m_mushroomPool;
    static PoolElements m_mushroomWallPool;
    public GameObject m_mushroomPrefab;
    public GameObject m_mushroomWallPrefab;
    public int m_maxMushrooms;

    [Range(0.0f, 1.0f)]
    public float m_LerpRotationPct = 0.9f;

    [Header("Inputs")]
    private PlayerInput m_playerInput;
    private InputAction m_moveAction;
    private InputAction m_jumpAction;

    private Vector2 currenInputVector;
    private Vector2 smoothInputVelocity;

    CharacterController m_CharacterController;
    CameraController m_CameraController;
    Rigidbody m_Rigidbody;

    [Header("Camera")]
    private InputAction m_AimAction;
    public Transform m_ShoulderCameraPosition;
    public Transform m_Bow;

    Vector3 m_StartPosition;
    Quaternion m_StartRotation;

    [Header("On Mushrooms")]
    public float m_bounceDuration;
    private float m_bounceTimer;
    private bool m_bouncing;
    private Vector3 m_bounceDirection;
    public float m_mushroomJumpSpeed = 10f;
    private bool m_jumpedOnMushroom;

    private void Awake()
    {
        m_CharacterController = GetComponent<CharacterController>();
        m_CameraController = m_Camera.GetComponent<CameraController>();
        m_Rigidbody = GetComponent<Rigidbody>();
        m_playerInput = GetComponent<PlayerInput>();
        m_moveAction = m_playerInput.actions["Movement"];
        m_jumpAction = m_playerInput.actions["Jump"];
        m_AimAction = m_playerInput.actions["Aim"];

        m_mushroomPool = new PoolElements(m_maxMushrooms, transform, m_mushroomPrefab);
        m_mushroomWallPool = new PoolElements(m_maxMushrooms, transform, m_mushroomWallPrefab);
    }
    void Start()
    {
        //m_StartPosition = transform.position;
        //m_StartRotation = transform.rotation;
    }

    void Update()
    {
        //Movement function
        Movement();

        RotWithCam();

        //Aim
        if (m_AimAction.triggered)
        {
            if (m_ShoulderCameraPosition.eulerAngles.x < 360 + m_CameraController.m_MinAimPitchDistance && m_ShoulderCameraPosition.eulerAngles.x > 180)
                m_CameraController.m_AimPitch = m_CameraController.m_MinAimPitchDistance;
            else if (m_ShoulderCameraPosition.eulerAngles.x >= 360 + m_CameraController.m_MinAimPitchDistance)
                m_CameraController.m_AimPitch = m_ShoulderCameraPosition.eulerAngles.x - 360;
            else
                m_CameraController.m_AimPitch = m_ShoulderCameraPosition.eulerAngles.x;

            m_CameraController.SetIsAiming(true);
        }
        if (m_AimAction.WasReleasedThisFrame())
        {
            m_CameraController.SetIsAiming(false);
        }
    }

    private void RotWithCam()
    {
        Vector3 l_Forward = m_Camera.transform.forward;
        l_Forward.y = 0.0f;
        transform.forward = l_Forward;

        Vector3 l_bowRot = m_Camera.transform.eulerAngles;
        m_Bow.eulerAngles = l_bowRot;
    }

    private void Movement()
    {
        Vector2 input = m_moveAction.ReadValue<Vector2>();

        Vector3 l_Forward = m_Camera.transform.forward;
        Vector3 l_Right = m_Camera.transform.right;
        l_Forward.y = 0.0f;
        l_Right.y = 0.0f;

        l_Forward.Normalize();
        l_Right.Normalize();

        Vector3 l_Movement = Vector3.zero;

        if (!m_bouncing)
        {
            //currenInputVector = Vector2.SmoothDamp(currenInputVector, input, ref smoothInputVelocity, smoothInputSpeed);
            //l_Movement = new Vector3(currenInputVector.x, 0, currenInputVector.y);
            l_Movement = l_Right * input.x;
            l_Movement += l_Forward * input.y;

            //l_Movement = l_Right * currenInputVector.x;
            //l_Movement += l_Forward * currenInputVector.y;

            float l_Speed = m_WalkSpeed;

            if (m_jumped)
            {
                l_Speed /= 3f;
            }

            l_Movement.Normalize();
            l_Movement *= l_Speed * Time.deltaTime;

            Jump();
        }
        else
        {
            l_Movement = -m_bounceDirection * 10f * Time.deltaTime;
            m_bounceTimer -= Time.deltaTime;
                if (m_bounceTimer < 0)
                {
                    m_bouncing = false;
                    m_bounceTimer = m_bounceDuration;
                }        
        }
        
        //Gravity needs refactoring
        if (m_VerticalSpeed < 0f)
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime * m_fallGravityMultiplier;
        }
        else
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime;
            m_jumpedOnMushroom = false;
        }

        l_Movement.y = m_VerticalSpeed * Time.deltaTime;

        CollisionFlags l_CollisionFlags = m_CharacterController.Move(l_Movement);

        if ((l_CollisionFlags & CollisionFlags.Below) != 0 && !m_jumpedOnMushroom)
        {
            m_OnGround = true;
            m_VerticalSpeed = 0.0f;
            m_onAirTimer = 0f;
            m_jumped = false;
        }
        else
        {
            m_OnGround = false;
            m_onAirTimer += Time.deltaTime;
        }

        if ((l_CollisionFlags & CollisionFlags.Above) != 0 && m_VerticalSpeed > 0.0f)
        {
            m_VerticalSpeed = 0.0f;
        }

        if (m_onAirTimer > 1f)
        {
            m_jumped = true;
        }
    }

    private void Jump()
    {
        if (m_jumpAction.triggered && (m_OnGround || m_onAirTimer < 0.3f))
        {
            m_VerticalSpeed = m_JumpSpeed;
            m_OnGround = false;
            m_jumped = true;
        }
    }

    public void SetVerticalSpeed(float newSpeed)
    {
        m_VerticalSpeed = newSpeed;
    }

    public float GetVerticalSpeed()
    {
        return m_VerticalSpeed;
    }

    public void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.collider.tag == "Mushroom")
        {
            Debug.DrawRay(hit.point, hit.normal, Color.red, 2f);
            if (hit.normal.y < 0.5f)
            {
                Debug.Log("A REBOTAR");
                m_bounceDirection = hit.transform.position - transform.position;
                m_bounceDirection.Normalize();
                m_bounceTimer = m_bounceDuration;
                m_bouncing = true;
            }
            else
            {
                m_jumpedOnMushroom = true;
                Debug.Log("A SALTAR");
                SetVerticalSpeed(m_mushroomJumpSpeed);
                m_jumped = true;
            }
        }
    }

    public static PoolElements GetPool(bool wall)
    {
        if (wall)
        {
            return m_mushroomWallPool;
        }
        else
        {
            return m_mushroomPool;
        }
    }

    //private void OnTriggerEnter(Collider other)
    //{
    //    if (other.CompareTag("Mushroom"))
    //    {
    //        //SetVerticalSpeed(10f);
    //        m_CharacterController.enabled = false;
    //        //m_Rigidbody.AddRelativeForce(transform.position * -10, ForceMode.Impulse);
    //        //_Rigidbody.AddForce(this.transform.InverseTransformDirection(this.transform.forward) * 1000, ForceMode.Impulse);
    //        //m_Rigidbody.AddRelativeForce(this.transform.InverseTransformDirection(this.transform.forward) * 100, ForceMode.Impulse);
    //        //m_Rigidbody.velocity = gameObject.transform.forward * -1000;
    //        //m_Rigidbody.AddExplosionForce(-10, other.GetComponent<Collision>().GetContact(0).point, 5);
    //        m_CharacterController.enabled = true;
    //        jumped = true;

    //        m_bounceDirection = other.transform.position - transform.position;

    //        m_bounceDirection.Normalize();
    //        m_bouncing = true;

    //        Debug.DrawRay(other.ClosestPoint(transform.position), transform.position, Color.red, 2f);
    //    }
    //}
}
