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

    public float smoothInputSpeed = 0.1f;

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
    float m_Timer;
    bool jumped;

    private void Awake()
    {
        m_CharacterController = GetComponent<CharacterController>();
        m_CameraController = m_Camera.GetComponent<CameraController>();
        m_Rigidbody = GetComponent<Rigidbody>();
        m_playerInput = GetComponent<PlayerInput>();
        m_moveAction = m_playerInput.actions["Movement"];
        m_jumpAction = m_playerInput.actions["Jump"];
        m_AimAction = m_playerInput.actions["Aim"];
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

        m_ShoulderCameraPosition.forward = m_Camera.transform.forward;

        // aim
        if (m_CameraController.GetIsAiming())
        {
            RotWithCam();
        }

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

            Vector3 l_Forward = transform.forward;
            l_Forward.y = 0.0f;
            m_Camera.transform.forward = l_Forward;
            m_Bow.eulerAngles = transform.eulerAngles;
        }
    }

    private void RotWithCam()
    {
        Vector3 l_Forward = m_Camera.transform.forward;
        l_Forward.y = 0.0f;
        transform.forward = l_Forward;

        Vector3 l_bowRot = m_ShoulderCameraPosition.eulerAngles;
        m_Bow.eulerAngles = l_bowRot;
    }

    private void Movement()
    {
        Vector2 input = m_moveAction.ReadValue<Vector2>();

        Vector3 l_Forward = m_Camera.transform.forward;
        //Vector3 l_Forward = gameObject.transform.forward;
        Vector3 l_Right = m_Camera.transform.right;
        //Vector3 l_Right = transform.right;
        l_Forward.y = 0.0f;
        l_Right.y = 0.0f;
        //l_Right.z = l_Forward.z;

        l_Forward.Normalize();
        l_Right.Normalize();

        Vector3 l_Movement = Vector3.zero;

        //currenInputVector = Vector2.SmoothDamp(currenInputVector, input, ref smoothInputVelocity, smoothInputSpeed);

        //l_Movement = new Vector3(currenInputVector.x, 0, currenInputVector.y);
        l_Movement = l_Right * input.x;
        //l_Movement = l_Forward * input.x;
        l_Movement += l_Forward * input.y;

        //l_Movement = l_Right * currenInputVector.x;
        //l_Movement += l_Forward * currenInputVector.y;

        float l_Speed = m_WalkSpeed;

        if (jumped)
        {
            l_Speed /= 3f;
        }

        l_Movement.Normalize();

        //if (input != Vector2.zero && !m_CameraController.GetIsAiming())
        //{
        //transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.LookRotation(l_Movement), m_LerpRotationPct);
        RotWithCam();
        //}

        l_Movement *= l_Speed * Time.deltaTime;

        Jump();

        //Gravity needs refactoring
        if (m_VerticalSpeed < 0f)
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime * 1.5f;
        }
        else
        {
            m_VerticalSpeed += Physics.gravity.y * Time.deltaTime;
        }

        l_Movement.y = m_VerticalSpeed * Time.deltaTime;

        CollisionFlags l_CollisionFlags = m_CharacterController.Move(l_Movement);

        if ((l_CollisionFlags & CollisionFlags.Below) != 0)
        {
            m_OnGround = true;
            m_VerticalSpeed = 0.0f;
            m_Timer = 0f;
            jumped = false;
        }
        else
        {
            m_OnGround = false;
            m_Timer += Time.deltaTime;
        }

        if ((l_CollisionFlags & CollisionFlags.Above) != 0 && m_VerticalSpeed > 0.0f)
        {
            m_VerticalSpeed = 0.0f;
        }

        if (m_Timer > 1f)
        {
            jumped = true;
        }
    }

    private void Jump()
    {
        if (m_jumpAction.triggered && (m_OnGround || m_Timer < 0.3f))
        {
            m_VerticalSpeed = m_JumpSpeed;
            m_OnGround = false;
            jumped = true;
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


    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Mushroom"))
        {
            //SetVerticalSpeed(10f);
            m_CharacterController.enabled = false;
            //m_Rigidbody.AddRelativeForce(transform.position * -10, ForceMode.Impulse);
            //_Rigidbody.AddForce(this.transform.InverseTransformDirection(this.transform.forward) * 1000, ForceMode.Impulse);
            //m_Rigidbody.AddRelativeForce(this.transform.InverseTransformDirection(this.transform.forward) * 100, ForceMode.Impulse);
            print(m_Rigidbody);
            //m_Rigidbody.velocity = gameObject.transform.forward * -1000;
            //m_Rigidbody.AddExplosionForce(-10, other.GetComponent<Collision>().GetContact(0).point, 5);
            m_CharacterController.enabled = true;
            jumped = true;
        }
    }

    //public void MushroomBounce()
    //{
    //    print("Patata");
    //    SetVerticalSpeed(10f);
    //    //gameObject.GetComponent<Rigidbody>().AddForce(Vector3.forward * -10);
    //    //m_Rigidbody.AddRelativeForce(Vector3.forward * 1000);

    //}

    //private void OnCollisionEnter(Collision collision)
    //{
    //    //Rigidbody otherRB = collision.rigidbody;
    //    if (collision.transform.tag == "Mushroom")
    //    {
    //        m_CharacterController.enabled = false;
    //        print("collision");
    //        m_Rigidbody.AddExplosionForce(10, collision.contacts[0].point, 5);
    //        m_CharacterController.enabled = true;
    //    }

    //}
}
