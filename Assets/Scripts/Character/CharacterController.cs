using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterController : MonoBehaviour
{
    public Camera m_Camera;

    [Header("Stats")]
    public float m_WalkSpeed = 1.5f;

    [Header("Inputs")]
    //public KeyCode m_RightKeyCode = KeyCode.D;
    //public KeyCode m_LeftKeyCode = KeyCode.A;
    //public KeyCode m_UpKeyCode = KeyCode.W;
    //public KeyCode m_DownKeyCode = KeyCode.S;

    CharacterController m_CharacterController;

    Vector3 m_StartPosition;
    Quaternion m_StartRotation;

    private void Awake()
    {
        m_CharacterController = GetComponent<CharacterController>();
    }
    void Start()
    {
        m_StartPosition = transform.position;
        m_StartRotation = transform.rotation;
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

        //Movement needs refactoring with new input system
        //if (Input.GetKey(m_RightKeyCode))
        //{
        //    l_Movement = l_Right;
        //}
        //else if (Input.GetKey(m_LeftKeyCode))
        //{
        //    l_Movement -= l_Right;
        //}
        //if (Input.GetKey(m_UpKeyCode))
        //{
        //    l_Movement += l_Forward;
        //}
        //else if (Input.GetKey(m_DownKeyCode))
        //{
        //    l_Movement -= l_Forward;
        //}

        float l_Speed = m_WalkSpeed;

        l_Movement.Normalize();

        l_Movement *= l_Speed * Time.deltaTime;

        //Jump needs refactoring
        //if (Input.GetKeyDown(KeyCode.Space) && m_VerticalSpeed == 0.0f)
        //{
        //    m_VerticalSpeed = m_JumpSpeed;
        //}

        //Gravity needs refactoring
        //m_VerticalSpeed += Physics.gravity.y * Time.deltaTime;
        //l_Movement.y = m_VerticalSpeed * Time.deltaTime;

        //CollisionFlags l_CollisionFlags = m_CharacterController.Move(l_Movement);

        //if ((l_CollisionFlags & CollisionFlags.Below) != 0 && m_VerticalSpeed < 0.0f)
        //{
        //    m_LongJumping = false;
        //    m_WallJumping = false;
        //    m_OnGround = true;
        //    m_VerticalSpeed = 0.0f;
        //    m_Timer = 0f;
        //    m_JumpComboTimer += Time.deltaTime;
        //}
        //else
        //{
        //    m_OnGround = false;
        //    m_Timer += Time.deltaTime;
        //}

    }
}
