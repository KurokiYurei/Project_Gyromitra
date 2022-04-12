using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CharacterControllerScript : MonoBehaviour
{
    public Camera m_Camera;

    [Header("Stats")]
    public float m_WalkSpeed = 1.5f;
    private bool m_OnGround;
    public float m_VerticalSpeed = 0.0f;

    public float smoothInputSpeed = 0.1f;

    [Range(0.0f, 1.0f)]
    public float m_LerpRotationPct = 0.9f;

    [Header("Inputs")]
    private PlayerInput playerInput;
    private InputAction moveAction;

    private Vector2 currenInputVector;
    private Vector2 smoothInputVelocity;

    CharacterController m_CharacterController;

    Vector3 m_StartPosition;
    Quaternion m_StartRotation;
    private float m_Timer;

    private void Awake()
    {
        m_CharacterController = GetComponent<CharacterController>();
        playerInput = GetComponent<PlayerInput>();
        moveAction = playerInput.actions["Movement"];
    }
    void Start()
    {
        //m_StartPosition = transform.position;
        //m_StartRotation = transform.rotation;
    }

    void Update()
    {
        Vector3 l_Forward = m_Camera.transform.forward;
        Vector3 l_Right = m_Camera.transform.right;
        l_Forward.y = 0.0f;
        l_Right.y = 0.0f;

        l_Forward.Normalize();
        l_Right.Normalize();

        Vector3 l_Movement = Vector3.zero;
        Vector2 input = moveAction.ReadValue<Vector2>();

        //currenInputVector = Vector2.SmoothDamp(currenInputVector, input, ref smoothInputVelocity, smoothInputSpeed);

        //l_Movement = new Vector3(currenInputVector.x, 0, currenInputVector.y);
        l_Movement = l_Right * input.x;
        l_Movement += l_Forward * input.y;

        //l_Movement = l_Right * currenInputVector.x;
        //l_Movement += l_Forward * currenInputVector.y;

        float l_Speed = m_WalkSpeed;

        l_Movement.Normalize();

        if (input != Vector2.zero)
            transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.LookRotation(l_Movement), m_LerpRotationPct);

        l_Movement *= l_Speed * Time.deltaTime;

        //Jump needs refactoring
        //if (Input.GetKeyDown(KeyCode.Space) && m_VerticalSpeed == 0.0f)
        //{
        //    m_VerticalSpeed = m_JumpSpeed;
        //}

        //Gravity needs refactoring
        m_VerticalSpeed += Physics.gravity.y * Time.deltaTime;
        l_Movement.y = m_VerticalSpeed * Time.deltaTime;

        CollisionFlags l_CollisionFlags = m_CharacterController.Move(l_Movement);

        if ((l_CollisionFlags & CollisionFlags.Below) != 0 && m_VerticalSpeed < 0.0f)
        {
            //m_OnGround = true;
            m_VerticalSpeed = 0.0f;
            //m_Timer = 0f;
        }
        else
        {
            //m_OnGround = false;
            //m_Timer += Time.deltaTime;
        }

        if ((l_CollisionFlags & CollisionFlags.Above) != 0 && m_VerticalSpeed > 0.0f)
        {
            m_VerticalSpeed = 0.0f;
        }
    }
}
